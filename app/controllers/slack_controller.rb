class SlackController < ApplicationController

  skip_before_action :verify_authenticity_token

  def create_poll
    poll_name, poll_candidates = poll_params
    poll = Poll.new(name: poll_name.downcase, open: true)
    poll.save

    poll_candidates.each do |candidate|
      Candidate.new(name: candidate.strip.downcase, poll_id: poll.id).save
    end

    render json: poll, status: :success
  end

  def close_poll
    poll = get_poll
    poll.open = false
    poll.save

    render json: poll, status: :success
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
    render json: poll, status: :success
  end

  def see_candidates
    poll = get_poll
    candidates = Candidate.where(poll_id: poll.id)

    render json: candidates, status: :success
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

    poll = Poll.find(12)
    candidates = Candidate.where(poll_id: poll.id)

    candidate_list = candidates.collect{|x| x.id}

    winner_id = -1

    while(candidate_list.length > 2) do
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
      last = records_array.to_a[-1]
      candidate_list.delete(last["candidate_id"].to_i)
      winner_id = records_array.to_a[0]["candidate_id"].to_i
    end

    winner = Candidate.find(winner_id)
    render json: winner
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
      Poll.where(name: poll_name)[0]
    end
end