defmodule LiveViewStudioWeb.VehiclesLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Vehicles

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        vehicles: [],
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>🚙 Find a Vehicle 🚘</h1>
    <div id="vehicles">
      <form phx-submit="search">
        <input
          type="text"
          name="query"
          value=""
          placeholder="Make or model"
          autofocus
          autocomplete="off"
        />

        <button>
          <img src="/images/search.svg" />
        </button>
      </form>

      <div :if={@loading} class="loader"> Loading ...</div>

      <div class="vehicles">
        <ul>
          <li :for={vehicle <- @vehicles}>
            <span class="make-model">
              <%= vehicle.make_model %>
            </span>
            <span class="color">
              <%= vehicle.color %>
            </span>
            <span class={"status #{vehicle.status}"}>
              <%= vehicle.status %>
            </span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("search", %{"query" => query}, socket) do
    send(self(), {:search, query})
    socket = assign(socket, loading: true, vehicles: [])

    {:noreply, socket}
  end

  def handle_info({:search, query}, socket) do
    vehicles = Vehicles.search(query)
    socket = assign(socket, loading: false, vehicles: vehicles)
    {:noreply, socket}
  end
end
