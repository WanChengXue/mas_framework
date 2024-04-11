defmodule ModelTestWeb.Router do
  use ModelTestWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ModelTestWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ModelTestWeb do
    pipe_through :browser

    get "/", GameController, :game_home
    get "/load", GameController, :load_game
    get "/exit", GameController, :exit_game
    get "/new", GameController, :new_game
    get "/get_game_observation", GameController, :get_game_observation
    get "/new_actor", GameController, :new_actor
    get "/question", GameController, :question
  end

  # Other scopes may use custom stacks.
  # scope "/api", ModelTestWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:model_test, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ModelTestWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
