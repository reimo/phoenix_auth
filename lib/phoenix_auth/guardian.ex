
defmodule PhoenixAuth.Guardian do
  use Guardian, otp_app: :phoenix_auth

  # def subject_for_token(resource, _claims) do
  #   {:ok, to_string(resource.id)}
  # end

  # def resource_from_claims(claims) do
  #  
  # end

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