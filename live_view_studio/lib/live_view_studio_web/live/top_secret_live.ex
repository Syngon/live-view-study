defmodule LiveViewStudioWeb.TopSecretLive do
  use LiveViewStudioWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  defp pad_user_id(%{id: id}) do
    id
    |> Integer.to_string()
    |> String.pad_leading(3, "0")
  end

  def render(assigns) do
    ~H"""
    <div id="top-secret">
      <img src="/images/spy.svg" />
      <div class="mission">
        <h1>Top Secret</h1>
        <h2>Your Mission</h2>
        <h3><%= pad_user_id(@current_user) %></h3>
        <p class="font-montserrat">
          Storm the castle and capture 3 bottles of Elixir.
        </p>
      </div>

      <button class="bg-blue-600 hover:bg-blue-900 text-sm text-white rounded-md py-4 px-6 transition-all">
        VER MAIS EVENTOS
      </button>
    </div>
    """
  end
end
