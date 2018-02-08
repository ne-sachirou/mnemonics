defmodule ExampleWeb.MortalView do
  use ExampleWeb, :view
  alias ExampleWeb.MortalView

  def render("index.json", %{mortals: mortals}) do
    %{data: render_many(mortals, MortalView, "mortal.json")}
  end

  def render("show.json", %{mortal: mortal}) do
    %{data: render_one(mortal, MortalView, "mortal.json")}
  end

  def render("mortal.json", %{mortal: mortal}) do
    %{id: mortal.id, name: mortal.name}
  end
end
