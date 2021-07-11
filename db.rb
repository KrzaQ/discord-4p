require 'sequel'

def get_db_version db
    db[:registry].first(key: 'database_version').fetch(:value, 0).to_i
end

def set_db_version db, version
    db[:registry].where(key: 'database_version').update(value: version.to_s)
end

def create_tables_v1(db)
    db.create_table :registry do
        String :key, size: 40, index: true, unique: true
        String :value, null: true, default: nil, size: 2048
    end

    db.create_table :messages do
        Integer :discord_id, unique: true, index: true, null: false
        Integer :topic_id
        String :channel, size: 511, null: false
        Time :created, null: false, index: true, default: Sequel::CURRENT_TIMESTAMP
        Time :updated, null: true, default: nil, index: true
    end

    db.create_table :tags do
        String :tag, unique: true, size: 20, index: true, null: false
        String :channel, null: false, size: 511
    end

    db.create_table :categories do
        String :category, unique: true, size: 20, index: true, null: false
        String :channel, null: false, size: 511
    end

    db.create_table :hooks do
        String :channel, size: 40, index: true, unique: true
        String :value, size: 511, null: false
    end

    db[:registry].insert(key: 'database_version', value: 1)
end

def create_tables db
    version = if db.table_exists? :registry
        get_db_version(db) + 1
    else
        1
    end

    (version..).each do |n|
        db.transaction do
            print "Executing create_tables_v#{n}..."
            begin
                send "create_tables_v#{n}", db
                puts "ok"
            rescue NoMethodError
                puts "not found"
                return
            end
        end
    end
end

def drop_tables(db)
    db.drop_table? :registry
    db.drop_table? :messages
    db.drop_table? :hooks
end
