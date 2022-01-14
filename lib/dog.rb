class Dog
    attr_accessor :name, :breed, :id

    def initialize(dog_details)
        @name = dog_details[:name]
        @breed = dog_details[:breed]
        @id = (dog_details[:id] ? dog_details[:id] : nil)
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs(id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(inputs)
        new_dog = Dog.new(inputs)
        new_dog.save
    end

    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        dogs = DB[:conn].execute("SELECT * FROM dogs")
        dogs.map do |row|
            Dog.new_from_db(row)
        end
    end

    def self.find_by_name(search_name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?  LIMIT 1
        SQL
        dog = DB[:conn].execute(sql, search_name)
        Dog.new_from_db(dog[0])
    end

    def self.find(search_id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?  LIMIT 1
        SQL
        dog = DB[:conn].execute(sql, search_id)
        Dog.new_from_db(dog[0])
    end

end
