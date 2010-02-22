class CreateSampleRadiusTable < ActiveRecord::Migration
  def self.up
    # copied from live radiusd install
    create_table :radacct, :primary_key => 'radacctid' do |t|
#      t.integer :radacctid,    :limit => 8 # NOTE: radacctid is BIGINT in original radius table
      t.string :acctsessionid, :limit => 32, :null => false, :default => ''
      t.string :acctuniqueid,  :limit => 32, :null => false, :default => ''
      t.string :username,      :limit => 64, :null => false, :default => ''
      t.string :groupname,     :limit => 64, :null => false, :default => ''
      t.string :realm,         :limit => 64, :default => ''
      t.string :nasipaddress,  :limit => 15, :null => false, :default => ''
      t.string :nasportid,     :limit => 15
      t.string :nasporttype,   :limit => 32
      t.datetime :acctstarttime
      t.datetime :acctstoptime
      t.integer :acctsessiontime
      t.string :acctauthentic,     :limit => 32
      t.string :connectinfo_start, :limit => 50
      t.string :connectinfo_stop,  :limit => 50
      t.integer :acctinputoctets,  :limit => 8
      t.integer :acctoutputoctets, :limit => 8
      t.string :calledstationid,   :limit => 50, :null => false, :default => ''
      t.string :callingstationid,  :limit => 50, :null => false, :default => ''
      t.string :acctterminatecause,:limit => 32, :null => false, :default => ''
      t.string :servicetype,       :limit => 32
      t.string :framedprotocol,    :limit => 32
      t.string :framedipaddress,   :limit => 15, :null => false, :default => ''
      t.integer :acctstartdelay
      t.integer :acctstopdelay
      t.string :xascendsessionsvrkey, :limit => 10
    end
    %w'username framedipaddress acctsessionid acctsessiontime acctuniqueid acctstarttime acctstoptime nasipaddress'.each do |c|
      add_index :radacct, c
    end
  end

  def self.down
    drop_table :radacct
  end
end
