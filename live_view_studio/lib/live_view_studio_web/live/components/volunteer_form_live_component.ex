defmodule LiveViewStudioWeb.Components.VolunteerFormLiveComponent do
  use LiveViewStudioWeb, :live_component

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(socket) do
    form = volunteer_to_form()
    {:ok, assign(socket, form: form)}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(count: assigns.count + 1)

    {:ok, socket}
  end

  defp volunteer_to_form(attrs \\ %{}) do
    %Volunteer{}
    |> Volunteers.change_volunteer(attrs)
    |> to_form()
  end

  def handle_event("validate", %{"volunteer" => volunteer_params}, socket) do
    form =
      %Volunteer{}
      |> Volunteers.change_volunteer(volunteer_params)
      |> Map.put(:action, :validate)
      |> to_form()

    socket = assign(socket, form: form)

    {:noreply, socket}
  end

  def handle_event("save", %{"volunteer" => volunteer_params}, socket) do
    case Volunteers.create_volunteer(volunteer_params) do
      {:ok, volunteer} ->
        socket = put_flash(socket, :info, "Volunteer successfully checked in!")
        send(self(), {:volunteer_created, volunteer})
        form = volunteer_to_form()

        {:noreply, assign(socket, form: form)}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket =
          socket
          |> assign(form: to_form(changeset))
          |> put_flash(:error, "Volunteer could not be checked in due to errors.")

        {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div>
      <div class="count">
        Go for it! You'll be volunteer <strong><%= @count %></strong>.
      </div>
      <.form
        for={@form}
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <.input
          field={@form[:name]}
          placeholder="Name"
          autocomplete="off"
          phx-debounce="2000"
        />
        <.input
          field={@form[:phone]}
          type="tel"
          placeholder="Phone"
          autocomplete="off"
          phx-debounce="blur"
          phx-hook="PhoneNumber"
        />

        <.button phx-disable-with="Saving...">
          Check in
        </.button>
      </.form>
    </div>
    """
  end
end
