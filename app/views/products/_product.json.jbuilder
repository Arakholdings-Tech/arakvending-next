json.extract! product, :id, :mechine_id, :name, :price, :selection, :quantity, :created_at, :updated_at
json.url product_url(product, format: :json)
