class SlackController < ApplicationController

  skip_before_action :verify_authenticity_token

  def create_poll
    poll_name, poll_candidates = poll_params
    poll = Poll.new(name: poll_name.downcase, open: true)
    poll.save

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

    render json: msg, status: :success
  end

  def close_poll
    poll = get_poll
    poll.open = false
    poll.save

    msg = {
      "response_type" =>  "in_channel",
      "text" => "Poll Closed: #{poll_name}"
    }

    render json: msg, status: :success
  end

  def vote
    poll_name, poll_candidates = poll_params
    poll = Poll.where(name: poll_name)[0]
    if(!poll.open)
      render json: "This poll is closes #{poll}"
      return
    end

    cur_votes = Vote.where(poll_id: poll.id, voter:user_id).each do |old_vote|
      old_vote.destroy
    end

    poll_candidates.each_with_index do |candidate, index|
      c_list = Candidate.where(name: candidate.strip.downcase, poll_id: poll.id)
      if(c_list.length != 1)
        render json: "This candidate is invalid #{candidate.strip.downcase}. Expecting 1 found #{c_list.length}"
        return
      end
      c = c_list[0]
      Vote.new(voter: user_id, poll_id: poll.id, candidate_id: c.id, priority: index).save
    end

    votes = Vote.where(poll_id: poll.id, voter: user_id)
    list = votes.collect do |v|
      {
        "text" =>  "#{v.name} #{v.priority}"
      }
    end

    msg = {
      "response_type" =>  "ephemeral",
      "text" => "You Voted In: #{poll_name}",
      "attachments" => list
    }

    render json: msg, status: :success
  end

  def see_candidates
    poll = get_poll
    candidates = Candidate.where(poll_id: poll.id)
    list = candidates.collect do |c|
      {
        "text" => c.name
      }
    end

    msg = {
      "response_type" =>  "ephemeral",
      "text" => "Candidates In: #{poll_name}",
      "attachments" => list
    }

    render json: msg, status: :success
  end

  def see_standings
    poll = get_poll

    candidates = Candidate.where(poll_id: poll.id)
    votes = Vote.where(poll_id: poll.id)

    render json: {
      "candidates" => candidates,
      "votes"=>  votes}
  end

  def see_winner
    poll = get_poll

    candidates = Candidate.where(poll_id: poll.id)

    candidate_list = candidates.collect{|x| x.id}

    winner_id = -1

    while(candidate_list.length > 1) do
      sql = "select candidate_id,count(*) from votes,
              (
              select voter, min(priority) as priority from votes
              where
                poll_id = #{poll.id} and
                candidate_id in (#{candidate_list.join(",")})
              group by voter
              ) as best_vote
            where
              best_vote.voter = votes.voter and
              best_vote.priority = votes.priority
            group by candidate_id
            order by count(*) DESC;"

      records_array = ActiveRecord::Base.connection.execute(sql)
      if(records_array.to_a.length == 0)
        msg = {
          "response_type" =>  "ephemeral",
          "text" => "No Winner In: #{poll_name}"
        }

        render json: msg, status: :success
        return
      end
      last = records_array.to_a[-1]
      candidate_list.delete(last["candidate_id"].to_i)
      winner_id = records_array.to_a[0]["candidate_id"].to_i
    end

    if(winner_id == -1)
      msg = {
        "response_type" =>  "ephemeral",
        "text" => "No Winner In: #{poll_name}"
      }

      render json: msg, status: :success
      return
    end

    winner = Candidate.find(winner_id)

    msg = {
      "response_type" =>  "ephemeral",
      "text" => "The Winner In: #{poll_name} is #{winner.name}"
    }

    render json: msg, status: :success
  end

  private
    def poll_params
      poll_name = params[:text].strip.split(" ")[0]
      poll_candidates = params[:text][/\[.*?\]/].slice(1..-2).split(",")
      return poll_name, poll_candidates
    end

    def poll_name
      poll_name = params[:text].strip
      return poll_name
    end

    def user_id
      return params[:user_id]
    end

    def get_poll
      p = Poll.where(name: poll_name)
      if(p.length == 0)
        render json: "no poll found with #{poll_name}", status: :failure
        return
      end
      p.last
    end
end
