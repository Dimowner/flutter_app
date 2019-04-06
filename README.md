# Share Place application
<p>
With this app you can share interesting places with users of the app.</br>
Main screen shows places list, items are clickable. Click on item image opens image preview, click on item opens map with marker on location where check-in was made.</br>
To share your place click the green floating action button, Check-in screen will open.</br>
Type your impression about the place click the blue locate button, wait until camera positioned to your location.</br>
Make sure that GPS is ON, unfortunately, the app can't display dialog to on GPS services. It caused by some problems of using in the project the latest Location library, and Location lib v 1.4.0 can't ask to on GPS.</br>
After location found and impression is typed, click button 'Next' to make a photo of your place you want to share.</br>
After photo was taken a new post will be inserted into Firebase database and after insertion is done places list will be updated with a new item on top of the list.</br>
All app users will receive this post.</br>
</p>
<p>
In addition to existing items appearance I was wanted to show google map on background of each item with marker on check-inned location.
But after implementing this list was quite laggy because of Google Map view in each item. So I tried to replace Google Map by screen shot of Google Map with marker.</br>
Unfortunately I didn't found a way how to do this programmatically, because all existing solution I found can't make screenshot of Google Map view. So now list just show a photo and impression.</br>
</p>
<p>
To make valid Google Map API key for all who build this project, 'debug.keystore' file was included into project.</br>
This keystore signs the debug and release builds by default.
</p>
<p>
Project created with Android Studio 3.3.2 targeting Android platform.
</p>