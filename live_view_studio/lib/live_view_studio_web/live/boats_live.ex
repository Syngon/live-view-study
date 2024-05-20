defmodule LiveViewStudioWeb.BoatsLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    filter = %{
      type: params["type"] || "",
      prices: params["prices"] || [""]
    }

    socket =
      assign(socket,
        filter: filter,
        boats: Boats.list_boats(filter)
      )

    {:noreply, socket}
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    filter = %{type: type, prices: prices}
    socket = push_patch(socket, to: ~p"/boats?#{filter}")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Daily Boat Rentals</h1>
    <div id="boats">


      <form phx-change="filter">
        <div class="filters">
          <select name="type">
            <%= Phoenix.HTML.Form.options_for_select(
              type_options(),
              @filter.type
            ) %>
          </select>
          <div class="prices">
            <%= for price <- ["$", "$$", "$$$"] do %>
              <input
                type="checkbox"
                name="prices[]"
                value={price}
                id={price}
                checked={price in @filter.prices}
              />
              <label for={price}><%= price %></label>
            <% end %>
            <input type="hidden" name="prices[]" value="" />
          </div>
        </div>
      </form>


      <div class="boats">
        <div :for={boat <- @boats} class="boat">
          <img src={boat.image} />
          <div class="content">
            <div class="model">
              <%= boat.model %>
            </div>
            <div class="details">
              <span class="price">
                <%= boat.price %>
              </span>
              <span class="type">
                <%= boat.type %>
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end
end
