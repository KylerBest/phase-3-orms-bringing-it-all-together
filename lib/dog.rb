class Dog
    attr_accessor :name, :breed, :id
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)

        self.id = DB[:conn].execute("SELECT id FROM dogs WHERE name = ?", self.name)[0][0]

        self
    end

    def self.create(name:, breed:)
        self.new(name: name, breed: breed).save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all 
        DB[:conn].execute("SELECT * FROM dogs").map do |row|
            self.new_from_db(row)
        end
    end

    def self.find_by_name(name)
        DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def self.find(id)
        DB[:conn].execute("SELECT * FROM dogs WHERE id = ? LIMIT 1", id).map do |row|
            self.new_from_db(row)
        end.first
    end
end
