require 'nokogiri'
require 'open-uri'

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
      head :ok
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
          self.class.lambda_numbeo_parser.call params[:country], params[:city]
        end
      end
      head :ok
    end

    # Отменяет предидущее
    def cancel_numbeo_parser
      self.class.thread_numbeo_parser.kill if !self.class.thread_numbeo_parser.nil? and self.class.thread_numbeo_parser.alive?
      head :ok
    end

    # Простая реализация контроллера по оповещению статува выполнения
    def status_numbeo_parcer
      status = ''
      if self.class.thread_numbeo_parser and self.class.thread_numbeo_parser.alive?
        status += self.class.thread_numbeo_parser[:status].to_s + ' : '
        status += self.class.thread_numbeo_parser[:item].to_s + ' '
        status += self.class.thread_numbeo_parser[:current].to_s + ' из '
        status += self.class.thread_numbeo_parser[:all].to_s
      elsif self.class.thread_recreate and self.class.thread_recreate.alive?
        status += self.class.thread_recreate[:status].to_s + ' : '
        status += self.class.thread_recreate[:item].to_s + ' '
        status += self.class.thread_recreate[:current].to_s + ' из '
        status += self.class.thread_recreate[:all].to_s
      end
      render json: {status: status}
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

            thread_recreate[:status] = 'Удаление'
            Country.destroy_all

            doc = Nokogiri::HTML(open('http://www.numbeo.com/cost-of-living/'))
            thread_recreate[:all] = doc.css('#country > option').size
            thread_recreate[:status] = 'Создание'

            doc.css('#country > option').each_with_index { |node, index|
              unless node.attribute('value').content.blank?

                begin

                  country = Country.create!(name: node.attribute('value').content)

                  thread_recreate[:item] = country.name
                  thread_recreate[:current] = index

                  doc = Nokogiri::HTML(open('http://www.numbeo.com/cost-of-living/country_result.jsp?country='+country.name.gsub(' ', '+')))
                  doc.css('#city > option').each { |node|
                    country.cities.build name: node.attribute('value').content unless node.attribute('value').content.blank?
                  }

                  country.save!
                rescue Exception
                  #   ignored
                end
              end

              sleep(rand(1) + rand(1000) / 1000.0)

            }

          end

        }
      end

      # Лямбда для потока парсинга мест
      def lambda_numbeo_parser
        lambda { |country_id = nil ,city_id = nil|

          ActiveRecord::Base.connection_pool.with_connection do

            currency = Currency.find_by_code 1

            i = 0
            thread_numbeo_parser[:status] = 'Парсинг Numbeo.com'
            thread_numbeo_parser[:all] = Country.count
            predicate_country = Country.where('1=1')
            unless  country_id.nil?
              predicate_country.where!(id: country_id.to_i)
            else
              Country.find_each {|c|
                c.analyzed = false
              }
            end
            predicate_country.find_each{ |country|
              deleted_country = PlacePosition.where(country_id: country.id)
              deleted_country.each {|c|
                c.delete
              }
              i += 1
              thread_numbeo_parser[:current] = i
              thread_numbeo_parser[:item] = country.name
              nokogiri = Nokogiri::HTML(open("http://www.numbeo.com/cost-of-living/country_result.jsp?displayCurrency=RUB&country=#{country.name.gsub(' ', '+')}"))

              category_name = ''
              category = nil
              nokogiri.css('.data_wide_table tr').each { |node|
                category_node = node.css('td.tr_highlighted_menu')

                if category_node.size != 0
                  category_name = category_node.first.content
                  category = Category.find_by_name(category_name)
                  if category.nil?
                    category = Category.create! name: category_name
                  end
                else
                  place_name = node.css('td:nth-child(1)').first.content
                  place = Place.find_by_name place_name
                  if place.nil?
                    place = Place.create! name: place_name, category: category
                  end
                  price = node.css('td:nth-child(2)').first.content

                  price.gsub!(' руб', '')
                  price.gsub!(',', '')
                  place_position = PlacePosition.create!(price: price.to_f, currency: currency)
                  place.place_positions << place_position
                  country.place_positions << place_position

                end

              }

              country.analyzed = true
              country.save!

              sleep(rand(2) + rand(1000) / 1000.0)

            }
            # PlacePosition.destroy_all
            i = 0
            thread_numbeo_parser[:status] = 'Парсинг Numbeo.com'
            thread_numbeo_parser[:all] = City.count
            predicate = City.where('1=1')
            unless  city_id.nil?
              predicate.where!(id: city_id)
            else
              City.find_each {|c|
                c.analyzed = false
              }
            end
            predicate.find_each{ |city|
              deleted_city = PlacePosition.where(city_id: city.id)
              deleted_city.each {|c|
                c.delete
              }
              i += 1
              thread_numbeo_parser[:current] = i
              thread_numbeo_parser[:item] = city.name
              nokogiri = Nokogiri::HTML(open("http://www.numbeo.com/cost-of-living/city_result.jsp?displayCurrency=RUB&country=#{city.country.name.gsub(' ', '+')}&city=#{city.name.gsub(' ', '+')}"))

              category_name = ''
              category = nil
              nokogiri.css('.data_wide_table tr').each { |node|
                category_node = node.css('td.tr_highlighted_menu')

                if category_node.size != 0
                  category_name = category_node.first.content
                  category = Category.find_by_name(category_name)
                  if category.nil?
                    category = Category.create! name: category_name
                  end
                else
                  place_name = node.css('td:nth-child(1)').first.content
                  place = Place.find_by_name place_name
                  if place.nil?
                    place = Place.create! name: place_name, category: category
                  end
                  price = node.css('td:nth-child(2)').first.content

                  price.gsub!(' руб', '')
                  place_position = PlacePosition.create!(price: price.to_f, currency: currency)
                  place.place_positions << place_position
                  city.place_positions << place_position

                end

              }

              city.analyzed = true
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
