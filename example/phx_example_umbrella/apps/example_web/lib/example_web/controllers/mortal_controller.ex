defmodule ExampleWeb.MortalController do
  use ExampleWeb, :controller

  alias Example.Mortals
  alias Example.Mortals.Mortal

  action_fallback(ExampleWeb.FallbackController)

  def index(conn, _params) do
    mortals = Mortals.list_mortals()
    render(conn, "index.json", mortals: mortals)
  end

  def create(conn, %{"mortal" => mortal_params}) do
    with {:ok, %Mortal{} = mortal} <- Mortals.create_mortal(mortal_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", mortal_path(conn, :show, mortal))
      |> render("show.json", mortal: mortal)
    end
  end

  def show(conn, %{"id" => id}) do
    mortal = Mortals.get_mortal!(id)
    render(conn, "show.json", mortal: mortal)
  end

  def update(conn, %{"id" => id, "mortal" => mortal_params}) do
    mortal = Mortals.get_mortal!(id)

    with {:ok, %Mortal{} = mortal} <- Mortals.update_mortal(mortal, mortal_params) do
      render(conn, "show.json", mortal: mortal)
    end
  end

  def delete(conn, %{"id" => id}) do
    mortal = Mortals.get_mortal!(id)

    with {:ok, %Mortal{}} <- Mortals.delete_mortal(mortal) do
      send_resp(conn, :no_content, "")
    end
  end
end
