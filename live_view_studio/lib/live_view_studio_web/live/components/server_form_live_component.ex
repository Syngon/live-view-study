defmodule LiveViewStudioWeb.Components.ServerFormLiveComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(socket) do
    form = server_to_form()
    {:ok, assign(socket, form: form)}
  end

  defp server_to_form(attrs \\ %{}, action \\ false) do
    changeset = Servers.change_server(%Server{}, attrs)

    changeset =
      case action do
        false -> changeset
        action -> Map.put(changeset, :action, action)
      end

    to_form(changeset)
  end

  def handle_event("validate", %{"server" => server_params}, socket) do
    form = server_to_form(server_params, :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"server" => server_params}, socket) do
    case Servers.create_server(server_params) do
      {:ok, server} ->
        socket =
          socket
          |> push_patch(to: ~p"/servers/#{server}")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> assign(form: to_form(changeset))
          |> put_flash(:error, "Server could not be created due to errors.")

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="field">
          <.input field={@form[:name]} placeholder="Name" />
        </div>
        <div class="field">
          <.input field={@form[:framework]} placeholder="Framework" />
        </div>
        <div class="field">
          <.input
            field={@form[:size]}
            placeholder="Size (MB)"
            type="number"
          />
        </div>
        <.button phx-disable-with="Saving...">
          Save
        </.button>

        <.link patch={~p"/servers"} class="cancel">
          Cancel
        </.link>
      </.form>
    </div>
    """
  end
end
