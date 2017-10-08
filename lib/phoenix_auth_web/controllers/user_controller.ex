defmodule PhoenixAuthWeb.UserController do
  use PhoenixAuthWeb, :controller

  alias PhoenixAuth.Auth
  alias PhoenixAuth.Auth.User

  def index(conn, _params) do
    users = Auth.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Auth.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Auth.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    changeset = Auth.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Auth.get_user!(id)

    case Auth.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Auth.get_user!(id)
    {:ok, _user} = Auth.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end


  def login(conn, _params) do
    
    changeset = Auth.change_user(%User{})
    render(conn, "login.html", changeset: changeset)
  end

  def sign_in(conn, %{"user" => %{"email" => email, "password" => pass}}) do
      case PhoenixAuth.Auth.authenticate(email, pass) do
        {:ok, user} ->
          
          conn =  PhoenixAuth.Guardian.Plug.sign_in(conn, user)
          conn
          |> put_flash(:info, "Login successful, Welcome to wonderland!")
          |>  redirect(to: "/secured/users")
        {:error, message} ->
          conn
          |> put_flash(:error, "Wrong username/password")
          |>  redirect(to: "/login")
       end
      
  end

  def sign_in(conn, _params) do
    send_resp(conn, 401, Poison.encode!(%{error: "Incorrect password"}))
  end

  def sign_out(conn, _params) do
    conn
    |> PhoenixAuth.Guardian.Plug.sign_out()
    #|> send_resp(204, "")
    |>  redirect(to: "/" )
  end

end
