defmodule LiveViewStudioWeb.BingoLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudioWeb.Presence
  @topic "users:bingo"

  def mount(_params, _session, socket) do
    %{current_user: current_user} = socket.assigns

    if connected?(socket) do
      :timer.send_interval(3000, self(), :pick)
      Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, @topic)

      {:ok, _} =
        Presence.track_user(current_user, @topic, %{
          time_joind: Timex.now() |> Timex.format!("%H:%M:%S", :strftime)
        })
    end

    presences = Presence.list_users(@topic)

    socket =
      assign(socket,
        number: nil,
        numbers: all_numbers()
      )
      |> assign(:presences, presences)

    {:ok, socket}
  end

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    socket = Presence.handle_diff(socket, diff)

    {:noreply, socket}
  end

  def handle_info(:pick, socket) do
    {:noreply, pick(socket)}
  end

  def render(assigns) do
    ~H"""
    <h1>Bingo Boss 📢</h1>
    <div id="bingo">
      <div class="users">
        <ul>
          <li :for={{_user_id, meta} <- @presences}>
            <span class="username">
              <%= meta.username %>
            </span>
            <span class="timestamp">
              <%= meta.time_joind %>
            </span>
          </li>
        </ul>
      </div>
      <div class="number">
        Numero: <%= @number %>
      </div>
    </div>
    """
  end

  # Assigns the next random bingo number, removing it
  # from the assigned list of numbers. Resets the list
  # when the last number has been picked.
  def pick(socket) do
    case socket.assigns.numbers do
      [head | []] ->
        assign(socket, number: head, numbers: all_numbers())

      [head | tail] ->
        assign(socket, number: head, numbers: tail)
    end
  end

  # Returns a list of all valid bingo numbers in random order.
  #
  # Example: ["B 4", "N 40", "O 73", "I 29", ...]
  def all_numbers() do
    ~w(B I N G O)
    |> Enum.zip(Enum.chunk_every(1..75, 15))
    |> Enum.flat_map(fn {letter, numbers} ->
      Enum.map(numbers, &"#{letter} #{&1}")
    end)
    |> Enum.shuffle()
  end
end
