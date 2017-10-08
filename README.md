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

~~~~

  pipeline :authorized do
    plug :fetch_session
    plug Guardian.Plug.Pipeline, module: PhoenixAuth.Guardian,
    error_handler: PhoenixAuth.AuthErrorHandler
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

 ~~~~


 













