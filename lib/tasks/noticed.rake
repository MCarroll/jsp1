namespace :noticed do
  desc "Clean-up invalid notifications"
  task cleanup: :environment do
    Noticed::Notification.find_each do |notification|
      notification.destroy if notification.deserialize_error?
    end
  end
end
