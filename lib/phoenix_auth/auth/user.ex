defmodule PhoenixAuth.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias PhoenixAuth.Auth.User


  schema "users" do
    field :email, :string
    field :fullname, :string
    field :hash_password, :string
    field :password, :string, virtual: true
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
