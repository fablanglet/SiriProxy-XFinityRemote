SiriProxy-XFinityRemote
=======================

A SiriProxy plugin that enables Siri to control your XFinityTV Set-Top Boxes.
Your Set-Top Boxe need to be compatible with the XFinityRemote TV App.

Requirements/Components
=======================

Eligible Set-Top Boxes
http://customer.comcast.com/help-and-support/xfinity-apps/eligible-cable-boxes-cable-tv-app/

Setup
=======================

The only setup required is to set your login/password of your comcast account.
Copy the contents of `config-info.yml` into your `~/.siriproxy/config.yml`.

Edit the config.yml so that the `login` and `password` value.
Then run `rvmsudo siriproxy bundle` from the console.