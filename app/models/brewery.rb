class Brewery < ApplicationRecord
    has_many :brewery_tags
    has_many :tags, through: :brewery_tags

    has_many :reviews, foreign_key: :reviewee_id
    has_many :reviewers, through: :reviews, source: :reviewer

    has_many :brewqueues
    has_many :users, through: :brewqueues

    def maps_helper
        if self.name.include?(" ") 
            name = self.name.split(" ").join("+") 
       else
            name = self.name
       end
       
       if self.city.include?(" ") 
           city = self.city.split(" ").join("+") 
       else
           city = self.city
       end
       
       if self.state.include?(" ") 
           state = self.state.split(" ").join("+") 
       else
           state = self.state
       end

       if self.street.empty?
         address = name + "+" + city + "+" + state
       else 
           street = self.street.split(" ").join("+")
           address = name + "+" + street + "+" + city + "+" + state
       end
       address
    end


    def maps_address
        if self.city && self.state
            address = self.maps_helper
        else 
            return false
        end
        return "https://www.google.com/maps/search/?api=1&query=#{address}"
    end


    def addy
        self.street + ", " + self.city + ", " + self.state + ", " + self.zip_code
    end

    def phone_number
        if !self.phone.empty?
            number = self.phone.to_s
            number.insert(3,"-")
            number.insert(7,"-")
        else
            return nil
        end
        number
    end

    def average_rating
        self.reviews.reduce(0) { |sum,review| sum + review.rating }/reviews.length.to_f
    end

    def num_of_brewqueues
        self.brewqueues.length
    end

    def random_profile_img
        arr_of_images = ["bar-img-1.jpeg", "bar-img-2.jpeg", "bar-img-3.jpeg", "bar-img-4.jpeg", "bar-img-5.jpeg", "bar-img-6.jpeg", "bar-img-7.jpeg", "bar-img-8.jpeg", "bar-img-9.jpeg"]

        arr_of_images.sample(1)[0] 
    end

    def self.highest_rated
        reviewed_breweries = Review.all.map do |review| review.reviewee if review.rating
        end
        rb = reviewed_breweries.uniq
        rb2 = rb.select {|rb| rb unless rb == nil }
        best = rb2.max_by { |brewery| brewery.average_rating }
        best
    end

    def self.city_most
        id = self.group("city").order('count(*) DESC').limit(1).pluck(:city).first 
    end

    #Below is sloooooow

    # def self.most_reviews
    #     self.all.max_by{|brewery| brewery.reviews.length}
    # end

    #fast version

    def self.most_reviews
        id = Review.group("reviewee_id").order('count(*) DESC').limit(1).pluck(:reviewee_id).first
        Brewery.find(id)
    end

    def self.state_most
        id = self.group("state").order('count(*) DESC').limit(1).pluck(:state).first 
    end


end
