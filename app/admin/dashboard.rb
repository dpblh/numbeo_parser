require 'nokogiri'

ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }



  content title: proc{ I18n.t("active_admin.dashboard") } do

      columns do

        column do
          panel 'Сбор информации о городах' do
            strong { link_to "Пересоздать страны и города из базы Numbeo", '/admin/recreate', remote: true, data: {confirm: 'Текущие данные будут утеряны'} }
            strong { link_to "Остановить сканирование городов Numbeo", '/admin/cancel_recreate', remote: true  }
          end
        end

        column do
          panel 'Сканирование мест' do
            section {
              strong { link_to "Сканировать Numbeo", '/admin/parser', remote: true, data: {confirm: 'Текущие данные будут утеряны'}  }
              strong { link_to "Остановить сканирование Numbeo", '/admin/cancel_numbeo_parser', remote: true  }
            }

          end
        end

        column do

          panel 'Сканирование мест в городе' do

            form action: '/admin/parser', method: 'get', class: 'formtastic place',id: :cities_submit, 'data-remote' => true do
              fieldset do
                ol {
                  li class: 'select input optional' do
                    label 'Страна', class: :label, for: :country
                    select name: :country, id: :countries_selector do
                      Country.select(:name, :id).each { |c|
                        option value: c.id do
                          c.name
                        end
                      }
                    end
                  end
                  li class: 'select input optional' do
                    label 'Город', class: :label, for: :city
                    select name: :city, id: :cities_selector do
                      # City.select(:name, :id).each { |c|
                      #   option value: c.id do
                      #     c.name
                      #   end
                      # }
                    end
                  end
                }
              end
              fieldset class: :actions do
                ol {
                  li class: 'action input_action' do
                    button_to 'Сканировать'
                  end
                }
              end

            end

          end

        end

      end
  end # content


  # Дополнительные контроллеры
  controller do

    # Пересоздает базу городов
    def recreate

      if self.class.thread_recreate.nil? or !self.class.thread_recreate.alive?
        self.class.thread_recreate = Thread.new do
          self.class.lambda_recreate.call
        end
      end

    end

    # Отменяет предидущее
    def cancel_recreate
      self.class.thread_recreate.kill if !self.class.thread_recreate.nil? and self.class.thread_recreate.alive?
      head :ok
    end

    # Собераем места
    def numbeo_parser
      if self.class.thread_numbeo_parser.nil? or !self.class.thread_numbeo_parser.alive?
        self.class.thread_numbeo_parser = Thread.new do
          self.class.lambda_numbeo_parser.call params[:city]
        end
      end
    end

    # Отменяет предидущее
    def cancel_numbeo_parser
      self.class.thread_numbeo_parser.kill if !self.class.thread_numbeo_parser.nil? and self.class.thread_numbeo_parser.alive?
      head :ok
    end

    # Простая реализация контроллера по оповещению статува выполнения "пересоздания базы городов"
    def status_recreate
      status = {}
      if self.class.thread_recreate.alive?
        status[:status] = self.class.thread_recreate[:status].to_s
        status[:country] = self.class.thread_recreate[:country].to_s
        status[:all] = self.class.thread_recreate[:all].to_s
        status[:current] = self.class.thread_recreate[:current].to_s
      else
        status[:status] = 'success'
      end
      render json: status
    end

    # Простая реализация контроллера по оповещению статува выполнения "Сбора мест"
    def status_numbeo_parcer
      status = {}
      if self.class.thread_numbeo_parser.alive?
        status[:status] = self.class.thread_numbeo_parser[:status].to_s
        status[:country] = self.class.thread_numbeo_parser[:country].to_s
        status[:all] = self.class.thread_numbeo_parser[:all].to_s
        status[:current] = self.class.thread_numbeo_parser[:current].to_s
      else
        status[:status] = 'success'
      end
      render json: status
    end

    # Контроллер перевода
    def translate
      place = Place.find(params[:id])
      place.name = params[:translate]
      place.translate = true
      place.save

      Place.where(name: place.name).each { |pl|
        pl.name = params[:translate]
        pl.translate = true
        pl.save
      }
      render json: place
    end

    # Контроллер рендерит <option></option> городов по стране
    def cities_by_country
      @cities = City.select(:name, :id).where(country_id: params[:id]).map {|c| [c.name, c.id]}
    end




    class << self

      # Лямбда для потока по созданию городов
      def lambda_recreate
        lambda {

          ActiveRecord::Base.connection_pool.with_connection do

            thread_recreate[:status] = 'destroy_all'
            Country.destroy_all
            countries = File.readlines(Rails.root.join('country'))
            thread_recreate[:all] = countries.size
            thread_recreate[:status] = 'in progress'

            countries.each_with_index { |country_name, index|
              begin
                country_name.gsub!("\n", '')
                country = Country.create!(name: country_name)

                thread_recreate[:country] = country_name
                thread_recreate[:current] = index

                uri = URI('http://www.numbeo.com/cost-of-living/country_result.jsp?country='+country_name.gsub(' ', '+'))
                responder = Net::HTTP.get(uri)
                doc = Nokogiri::HTML(responder)
                doc.css('#city > option').each { |node|
                  country.cities.build name: node.content unless node.content == '--- Select city---'
                }

                country.save!
              rescue Exception
                #   ignored
              end

              sleep(rand(1) + rand(1000) / 1000.0)

            }

          end

        }
      end

      # Лямбда для потока парсинга мест
      def lambda_numbeo_parser
        lambda { |id = nil|

          ActiveRecord::Base.connection_pool.with_connection do
            i = 0
            thread_numbeo_parser[:status] = 'in pregress'
            thread_numbeo_parser[:all] = City.count
            predicate = City.where('1=1')
            predicate.where!(id: id) unless  id.nil?
            predicate.find_each{ |city|
              i += 1
              thread_numbeo_parser[:current] = i
              url = "http://www.numbeo.com/cost-of-living/city_result.jsp?displayCurrency=RUB&country=#{city.country.name.gsub(' ', '+')}&city=#{city.name.gsub(' ', '+')}"
              uri = URI(url)
              document = Net::HTTP.get(uri)
              nokogiri = Nokogiri::HTML(document)

              category_name = ''
              category = nil
              currency = Currency.find_by_code 1
              nokogiri.css('.data_wide_table tr').each { |node|
                category_node = node.css('td.tr_highlighted_menu')

                if category_node.size != 0
                  category_name = category_node.first.content
                  category = Category.find_by_name(category_name)
                  if category.nil?
                    category = Category.create! name: category_name
                  end
                else
                  place = node.css('td:nth-child(1)').first.content
                  place.gsub!("\n", '')
                  price = node.css('td:nth-child(2)').first.content
                  price.gsub!("\n", '')
                  price.gsub!(' руб', '')
                  city.places.build name: place, price: price.to_f, currency: currency, category: category

                end

              }

              city.save!

              sleep(rand(2) + rand(1000) / 1000.0)

            }
          end

        }
      end

      # модификаторы доступа к потокам
      attr_accessor :thread_recreate
      attr_accessor :thread_numbeo_parser

    end


  end

end
