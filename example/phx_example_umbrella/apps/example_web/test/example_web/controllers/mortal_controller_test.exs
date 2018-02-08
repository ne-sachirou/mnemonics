defmodule ExampleWeb.MortalControllerTest do
  use ExampleWeb.ConnCase

  alias Example.Mortals
  alias Example.Mortals.Mortal

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:mortal) do
    {:ok, mortal} = Mortals.create_mortal(@create_attrs)
    mortal
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all mortals", %{conn: conn} do
      conn = get(conn, mortal_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create mortal" do
    test "renders mortal when data is valid", %{conn: conn} do
      conn = post(conn, mortal_path(conn, :create), mortal: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, mortal_path(conn, :show, id))
      assert json_response(conn, 200)["data"] == %{"id" => id, "name" => "some name"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, mortal_path(conn, :create), mortal: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update mortal" do
    setup [:create_mortal]

    test "renders mortal when data is valid", %{conn: conn, mortal: %Mortal{id: id} = mortal} do
      conn = put(conn, mortal_path(conn, :update, mortal), mortal: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, mortal_path(conn, :show, id))
      assert json_response(conn, 200)["data"] == %{"id" => id, "name" => "some updated name"}
    end

    test "renders errors when data is invalid", %{conn: conn, mortal: mortal} do
      conn = put(conn, mortal_path(conn, :update, mortal), mortal: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete mortal" do
    setup [:create_mortal]

    test "deletes chosen mortal", %{conn: conn, mortal: mortal} do
      conn = delete(conn, mortal_path(conn, :delete, mortal))
      assert response(conn, 204)

      assert_error_sent(404, fn ->
        get(conn, mortal_path(conn, :show, mortal))
      end)
    end
  end

  defp create_mortal(_) do
    mortal = fixture(:mortal)
    {:ok, mortal: mortal}
  end
end
