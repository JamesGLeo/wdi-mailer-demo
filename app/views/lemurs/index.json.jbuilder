json.array!(@lemurs) do |lemur|
  json.extract! lemur, :id, :name, :email
  json.url lemur_url(lemur, format: :json)
end
