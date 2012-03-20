##What this is##

This is a simple program for testing the Google Calendar API. I've created it to show some of the sporadic issues I've seen. There are two, although I'm not really sure if they're independent:

 1. Random 503 errors. Posted about [here](https://groups.google.com/d/topic/google-calendar-api/EVY3moTviAk/discussion)
 2. Random Quota Exceeded errors. Posted about [here](https://groups.google.com/d/topic/google-calendar-api/E1fO8jsoXaE/discussion)

 I have been able to reproduce both issues directly using this simple program. Sometimes it works, sometimes it fails, sometimes with a 503 and sometimes with a quota error. Whether it's actually caused by something else I'm doing earlier or just a straight-up issue with this code running on its own, I'm not sure (though I will say my real-life code does something very similar). But I'm not sure how I could do better.

##Running it##

 You'll need ruby > 1.9.2. Clone the repo and run `bundle install`. You run the code like this:

     ruby test.rb <app key> <secret> <refresh token>

Where `refresh token` is a valid OAuth2 refresh token for a user with a calendar. The program lists the user's calendars, creates a calendar, modifies its ACL, and then deletes that calendar. The one risk it poses is that if it fails halfway through, it'll leave a junky calendar in your calendar list.

One change you might have to make to the code is to specify the location of your SSL certs, or more likely, just remove the code that specifies it. The code I have works on Ubuntu and Linux Mint, but if you're on a Mac or something, that part may be different.

##What might happen##

Here's a sample output:

    TASK: getting the list of calendars
    Sending get to https://www.googleapis.com/calendar/v3/users/me/calendarList, body: 
    `primary calendar name here`
    TASK: creating a new calendar
    Sending post to https://www.googleapis.com/calendar/v3/calendars, body: {"summary":"Hey, a calendar!"}
    Error: {"errors"=>[{"domain"=>"usageLimits", "reason"=>"quotaExceeded", "message"=>"Quota Exceeded"}], "code"=>403, "message"=>"Quota Exceeded"}, Description: 
    Response: {
     "error": {
      "errors": [
       {
        "domain": "usageLimits",
        "reason": "quotaExceeded",
        "message": "Quota Exceeded"
       }
      ],
      "code": 403,
      "message": "Quota Exceeded"
     }
    }
    /home/isaac/.rvm/gems/ruby-1.9.2-p290/gems/oauth2-0.5.2/lib/oauth2/client.rb:107:in `request': OAuth2::Error (OAuth2::Error)
      from /home/isaac/.rvm/gems/ruby-1.9.2-p290/gems/oauth2-0.5.2/lib/oauth2/access_token.rb:98:in `request'
      from test.rb:47:in `make_request'
      from test.rb:64:in `<main>'

Where, like I said in the thread, there's no way I've really hit a quota issue. The 503 looks very similar