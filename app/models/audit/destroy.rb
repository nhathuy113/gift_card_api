class Audit::Destroy < Audit::Base
  def self.write(model, snapshot)
    super(model, before: snapshot)
  end
end
