defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server
  alias LiveViewStudioWeb.Components.ServerFormLiveComponent

  def mount(_params, _session, socket) do
    if connected?(socket), do: Servers.subscribe()
    servers = Servers.list_servers()

    socket =
      assign(socket,
        servers: servers,
        coffees: 0
      )

    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _uri, socket) do
    case Servers.get_server(id) do
      nil ->
        socket =
          socket
          |> put_flash(:error, "Server not found!")
          |> push_patch(to: "/servers")

        {:noreply, socket}

      server ->
        {:noreply, assign(socket, selected_server: server)}
    end
  end

  def handle_params(_, _uri, socket) do
    socket =
      if socket.assigns.live_action == :new do
        assign(socket, selected_server: nil)
      else
        selected_server = hd(socket.assigns.servers)
        assign(socket, selected_server: selected_server)
      end

    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    server = Servers.get_server!(id)
    new_status = new_status(server)

    {:ok, _server} =
      Servers.update_server(
        server,
        %{status: new_status}
      )

    {:noreply, socket}
  end

  def handle_event("drink", _, socket) do
    {:noreply, update(socket, :coffees, &(&1 + 1))}
  end

  def handle_info({:server_updated, server}, socket) do
    socket =
      update(socket, :servers, fn servers ->
        Enum.map(servers, fn s ->
          if s.id == server.id, do: server, else: s
        end)
      end)

    socket =
      if socket.assigns.selected_server != nil and socket.assigns.selected_server.id == server.id do
        socket
        |> put_flash(:info, "Server #{server.name} updated status to #{server.status}!")
        |> assign(selected_server: server)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_info({:server_created, server}, socket) do
    socket =
      socket
      |> update(:servers, &[server | &1])
      |> put_flash(:info, "Server #{server.name} created!")

    {:noreply, socket}
  end

  defp new_status(%Server{status: "up"}), do: "down"
  defp new_status(%Server{status: "down"}), do: "up"

  def render(assigns) do
    ~H"""
    <h1>Servers</h1>
    <div id="servers">
      <div class="sidebar">
        <div class="nav">
          <.link patch={~p"/servers/new"} class="add">
            + Add New Server
          </.link>

          <a
            id={"#{@selected_server.id}-clipboard"}
            data-content={
              url(@socket, ~p"/servers/?id=#{@selected_server}")
            }
            phx-hook="Clipboard"
          >
            Copy Link
          </a>

          <.link
            :for={server <- @servers}
            class={if server == @selected_server, do: "selected"}
            patch={~p"/servers/#{server}"}
          >
            <span class={server.status}></span>
            <%= server.name %>
          </.link>
        </div>
        <div class="coffees">
          <button phx-click="drink">
            <img src="/images/coffee.svg" />
            <%= @coffees %>
          </button>
        </div>
      </div>
      <div class="main">
        <div class="wrapper">
          <%= if @live_action == :new do %>
            <.live_component module={ServerFormLiveComponent} id={:new} />
          <% else %>
            <.server selected_server={@selected_server} />
          <% end %>

          <div class="links"></div>
        </div>
      </div>
    </div>
    """
  end

  def server(assigns) do
    ~H"""
    <div class="server">
      <div class="header">
        <h2><%= @selected_server.name %></h2>
        <button
          class={@selected_server.status}
          phx-click="toggle-status"
          phx-value-id={@selected_server.id}
        >
          <%= @selected_server.status %>
        </button>
      </div>
      <div class="body">
        <div class="row">
          <span>
            <%= @selected_server.deploy_count %> deploys
          </span>
          <span>
            <%= @selected_server.size %> MB
          </span>
          <span>
            <%= @selected_server.framework %>
          </span>
        </div>
        <h3>Last Commit Message:</h3>
        <blockquote>
          <%= @selected_server.last_commit_message %>
        </blockquote>
      </div>
    </div>

    <div class="links">
      <.link navigate={~p"/topsecret"} class="back">
        Top Secret
      </.link>
    </div>
    """
  end
end
