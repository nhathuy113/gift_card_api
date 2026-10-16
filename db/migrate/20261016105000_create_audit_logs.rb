class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :user, foreign_key: true
      t.string :action, null: false
      t.references :auditable, polymorphic: true
      t.jsonb :before_values
      t.jsonb :after_values
      t.string :outcome, null: false, default: "success"
      t.string :ip
      t.string :user_agent
      t.jsonb :metadata, null: false, default: {}
      t.datetime :created_at, null: false
    end

    add_index :audit_logs, :created_at
    add_index :audit_logs, :action
    add_index :audit_logs, [ :action, :created_at ]
    add_check_constraint :audit_logs, "outcome IN ('success', 'refused')", name: "audit_logs_outcome_check"
  end
end
