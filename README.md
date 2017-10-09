# phoenix_auth
User authentication using guardian with phoenix framework elixir
![Login](https://raw.githubusercontent.com/reimo/phoenix_auth/master/Untitled20171008230130.png)


#Step 1 ( great a new phoenix project or skip if u have an existing project )

mix phx.new phoenix_auth

#Step 2 ( Using phoenix generator to create schemas, controller etc )

mix phx.gen.html Auth User users username:string:unique email:string:unique hash_password:string fullname:string phone:string

mix ecto.create

mix ecto.migrate


#Step 3 ( add guardian and comeonin to your project )
 ~~~~
 #add to mix
 {:comeonin, "~> 2.5"},
 {:guardian, "~> 1.0-beta"}
 ~~~~

  Comeonin will be used for encrption 
  Guardian will do everything authentication

#Step 4 ( update dependencies  )

mix depts.get

#Step 6 ( Add guardian config to your config  )

#config/config.exs
~~~~
config :phoenix_auth, PhoenixAuth.Guardian,
  issuer: "PhoenixAuth",
  secret_key: "4J4p7tPWoStA8nmCNxoBSj9Hu/d5uhJO7ma7cJ9WMHXbV3cHv3mdoKmdU0QL4OGm"
~~~~



#Step 5 ( create guardian.ex  )
//lib/phoenix_auth/guardian.ex

~~~~
defmodule PhoenixAuth.Guardian do
  use Guardian, otp_app: :phoenix_auth
  
  def subject_for_token(resource, _claims) do
    {:ok, to_string(resource.id)}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    {:ok, PhoenixAuth.Auth.get_user!(claims["sub"])}
  end
  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end

end
~~~~



#Step ( create auth_error_handler.ex  )
//lib/phoenix_auth/auth_error_handler.ex
~~~~
defmodule PhoenixAuth.AuthErrorHandler do
    import Plug.Conn
  
    def auth_error(conn, {type, _reason}, _opts) do
      body = Poison.encode!(%{message: to_string(type)})
      send_resp(conn, 401, body)
    end
  end

  ~~~~


#Step ( add router pipeline )

//lib/phoenix_auth_web/router.ex
~~~~

  pipeline :authorized do
    plug :fetch_session
    plug Guardian.Plug.Pipeline, module: PhoenixAuth.Guardian,
    error_handler: PhoenixAuth.AuthErrorHandler
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

 ~~~~


 #step ( edit user model )

//lib/phoenix_auth/auth/user.ex

 ~~~~
 defmodule PhoenixAuth.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias PhoenixAuth.Auth.User


  schema "users" do
    field :email, :string
    field :fullname, :string
    field :hash_password, :string
    field :password, :string, virtual: true #u should note this!
    field :phone, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :hash_password, :fullname, :phone, :password])
    |> validate_required([:username, :email, :fullname, :phone])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> put_password_hash()
  end


  def put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :hash_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end

end
~~~~


#Step ( Add )


~~~~
/lib/phoenix_auth_web/views/helpers.ex
defmodule PhoenixAuthWeb.ViewHelper do
    def current_user(conn), do: Guardian.Plug.current_resource(conn)
    def logged_in?(conn), do: Guardian.Plug.authenticated?(conn, [])
end

#import ( into phoenix_auth_web.ex )
/lib/phoenix_auth_web/phoenix_auth_web.ex
import PhoenixAuthWeb.ViewHelper


~~~~~


#step ( add to user controller )

~~~~


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


  ~~~~













