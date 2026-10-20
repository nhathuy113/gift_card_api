module Auditable
  extend ActiveSupport::Concern

  included do
    after_create { Audit::Create.write(self) }
    after_update { Audit::Update.write(self) }
    after_destroy { Audit::Destroy.write(self, attributes.except("updated_at")) }
  end
end
