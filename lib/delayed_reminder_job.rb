class DelayedReminderJob

  def initialize(*args)
    opts = args.extract_options!
    @sender_id = opts[:sender_id]
    @recipient_ids = Array(opts[:recipient_ids]).flatten.uniq
    @subject = opts[:subject]
    @message = opts[:message]
    @body = opts[:body]
  end

  def perform
    @recipient_ids.each do |r_id|
      Reminder.create(:sender => @sender_id,:recipient => r_id,:subject => @subject,:body => @body)
    end
  end

end
