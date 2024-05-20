defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudioWeb.Components.VolunteerFormLiveComponent
  alias Phoenix.LiveView.JS

  def mount(_params, _session, socket) do
    if connected?(socket), do: Volunteers.subscribe()

    volunteers = Volunteers.list_volunteers()

    socket =
      socket
      |> stream(:volunteers, volunteers)
      |> assign(:count, length(volunteers))

    {:ok, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)
    {:ok, _volunteer} = Volunteers.delete_volunteer(volunteer)
    {:noreply, socket}
  end

  def handle_event("toggle-status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    {:ok, _volunteer} =
      Volunteers.update_volunteer(volunteer, %{checked_out: !volunteer.checked_out})

    {:noreply, socket}
  end

  def handle_info({:volunteer_deleted, volunteer}, socket) do
    socket =
      socket
      |> assign(:count, socket.assigns.count - 1)
      |> stream_delete(:volunteers, volunteer)

    {:noreply, socket}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    socket =
      socket
      |> stream_insert(:volunteers, volunteer)
      |> assign(:count, socket.assigns.count)

    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    socket =
      socket
      |> stream_insert(:volunteers, volunteer, at: 0)
      |> assign(:count, socket.assigns.count + 1)

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Volunteer Check-In</h1>
    <div id="volunteer-checkin">
      <.live_component
        module={VolunteerFormLiveComponent}
        id={:new}
        count={@count}
      />

      <div id="volunteers" phx-update="stream">
        <.volunteer
          :for={{volunteer_id, volunteer} <- @streams.volunteers}
          volunteer={volunteer}
          id={volunteer_id}
        />
      </div>
    </div>
    """
  end

  defp volunteer(assigns) do
    ~H"""
    <div
      class={"volunteer #{if @volunteer.checked_out, do: "out"}"}
      id={@id}
    >
      <div class="name">
        <%= @volunteer.name %>
      </div>
      <div class="phone">
        <%= @volunteer.phone %>
      </div>
      <div class="status">
        <.link
          class="delete"
          phx-click={
            JS.push("delete", value: %{id: @volunteer.id})
            |> JS.hide(
              to: "##{@id}",
              transition: "ease duration-1000 scale-150"
            )
          }
          data-confirm="Are you sure?"
        >
          <.icon name="hero-trash-solid" />
        </.link>
        <button phx-click={
          JS.push("toggle-status", value: %{id: @volunteer.id})
          |> JS.transition("shake",
            to: "##{@id}",
            time: 500
          )
        }>
          <%= if @volunteer.checked_out,
            do: "Check In",
            else: "Check Out" %>
        </button>
      </div>
    </div>
    """
  end
end
