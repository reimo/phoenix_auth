defmodule PhoenixAuthWeb.Router do
  use PhoenixAuthWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authorized do
    plug :fetch_session
    plug Guardian.Plug.Pipeline, module: PhoenixAuth.Guardian,
    error_handler: PhoenixAuth.AuthErrorHandler
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixAuthWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/login", UserController, :login 
    post "/sign_in", UserController, :sign_in 
    resources "/users", UserController
  end


   scope "/secured", PhoenixAuthWeb do
    pipe_through [:browser, :authorized] # Use the default browser stack
    get "users/sign-out", UserController, :sign_out
    resources "/users", UserController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixAuthWeb do
  #   pipe_through :api
  # end
end
