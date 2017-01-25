class Logic
  def self.start_vote(params)
    poll_name = params[:poll_name]
    polls = Poll.where(name: poll_name).order(:created_at)
    if(polls.length == 0)
      return {
        "response_type" =>  "ephemeral",
        "text" => "no poll found with #{poll_name}"
      }
    end

    poll = polls[0]

    priority = 0

    candidates = Candidate.where(poll_id: poll.id)
    actions = candidates.collect do |c|
      {
        "name" => "#{c.name}",
        "text" => "#{c.name}",
        "type" => "button",
        "value" => "#{c.name} #{priority}"
      }
    end

    msg = {
      "replace_original" => true,
      "response_type" =>  "ephemeral",
      "text" => "Candidates In: #{poll_name}",
      "attachments" => {
        "text" => "Choose a game to play",
        "fallback" => "You are unable to choose a game",
        "callback_id" => "ignore",
        "color" => "#3AA3E3",
        "attachment_type" => "default",
        "actions" => actions
      }
    }

    return msg
  end


  def self.create_poll(params)
    poll_name = params[:poll_name]
    poll = Poll.new(name: poll_name.downcase, open: true)
    poll.save

    poll_candidates = params[:candidates]
    poll_candidates.each do |candidate|
      Candidate.new(name: candidate.strip.downcase, poll_id: poll.id).save
    end

    candidates = Candidate.where(poll_id: poll.id)
    list = candidates.collect  do |c|
      {
        "text" =>  c.name
      }
    end

    msg = {
      "response_type" =>  "in_channel",
      "text" => "New Poll Created: #{poll_name}",
      "attachments" => list
    }
  end

  def self.vote(params)

  end

  def self.see_candidates(params)

  end

  def self.close_poll(params)

  end

  def self.see_winner(params)

  end
end