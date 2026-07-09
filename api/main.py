from itertools import count

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, ConfigDict, Field

app = FastAPI(title="Arpege - Products API")


class ProductIn(BaseModel):
    model_config = ConfigDict(populate_by_name=True)

    name: str = Field(alias="Name", min_length=1)
    category: str = Field(alias="Category", min_length=1)
    unit_price: float = Field(alias="UnitPrice", ge=0)
    quantity: int = Field(alias="Quantity", ge=0)
    supplier: str = Field(alias="Supplier", min_length=1)


class Product(ProductIn):
    id: int = Field(alias="Id")


_products: dict[int, Product] = {}
_next_id = count(1)


@app.get("/")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/api/products", response_model=Product, status_code=status.HTTP_201_CREATED)
def create_product(payload: ProductIn) -> Product:
    new_id = next(_next_id)
    product = Product(id=new_id, **payload.model_dump())
    _products[new_id] = product
    return product


@app.get("/api/products/{product_id}", response_model=Product)
def get_product(product_id: int) -> Product:
    product = _products.get(product_id)
    if product is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Product not found")
    return product


@app.put("/api/products/{product_id}", response_model=Product)
def update_product(product_id: int, payload: ProductIn) -> Product:
    if product_id not in _products:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Product not found")
    product = Product(id=product_id, **payload.model_dump())
    _products[product_id] = product
    return product


@app.delete("/api/products/{product_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_product(product_id: int) -> None:
    if product_id not in _products:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="Product not found")
    del _products[product_id]
