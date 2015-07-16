require 'rails_helper'

RSpec.describe Cart::OrderItemsController, type: :controller do

  describe "updating quantities of items in the cart" do
    before :each do
      @max_quantity = 10
      Product.create(name: "buttons", seller_id: 1, price: 1_000, stock: @max_quantity)

      @order = Order.create(status: "pending")
      @initial_quantity = 3
      @item = OrderItem.create(order_id: 1, product_id: 1, quantity_ordered: @initial_quantity)
    end

    context "decreasing quantity" do
      it "assigns @item" do
        # @item = OrderItem.find_by(id: params[:id])
        patch :less, id: 1

        expect(assigns(:item)).to eq(@item)
      end

      it "redirects back to the cart" do
        patch :less, id: 1

        expect(response).to redirect_to(cart_path)
        expect(response).to have_http_status(302)
      end

      it "decreases the quantity by one" do
        patch :less, id: 1

        expect(assigns(:item).quantity_ordered).to eq(@initial_quantity - 1)
      end

      it "doesn't decrease the quantity below one" do
        (@initial_quantity + 1).times do
          patch :less, id: 1
        end

        expect(assigns(:item).quantity_ordered).to eq(1)
      end
    end

    context "increases quantity of cart item" do
      it "assigns @item" do
        # @item = OrderItem.find_by(id: params[:id])
        patch :more, id: 1

        expect(assigns(:item)).to eq(@item)
      end

      it "redirects back to the cart" do
        patch :more, id: 1

        expect(response).to redirect_to(cart_path)
        expect(response).to have_http_status(302)
      end

      it "increases the quantity by one" do
        patch :more, id: 1

        expect(assigns(:item).quantity_ordered).to eq(@initial_quantity + 1)
      end

      it "doesn't increase the quantity beyond what's currently in stock" do
        (@max_quantity + 1).times do
          patch :more, id: 1
        end

        expect(assigns(:item).quantity_ordered).to eq(@max_quantity)
      end

      it "even if some of the stock is tied up in other pending orders" do
        already_tied_quantity = 5
        Order.create(status: "pending")
        OrderItem.create(order_id: 2, product_id: 1, quantity_ordered: already_tied_quantity)

        (@max_quantity + 1).times do
          patch :more, id: 1
        end

        expect(assigns(:item).quantity_ordered).to eq(@max_quantity - already_tied_quantity)
      end
    end
  end
end