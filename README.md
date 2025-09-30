# captcha-demo

Hold the Captcha Demo for customers

The purpose of this repo is show a working example of the App47 Captcha Service using a simple static web site:

* [index.html](web/index.html)
* [success.html](web/success.html)
* [error.html](web/error.html)

Along with a single lambda function that acts as the form handler for the static web site.

* [submit.py](lambda/submit.py)

This demo does not implement any strong security measures for starting the captcha process, but does highlight where that would plug in.

## Browser setup and configuration

The browser showing the captcha input must have two elements, the captcha div and the captcha JS file. Let's start with the 
captcha div. In your form, where you would like the captcha element placed, put the following snippet.

```html
        <!-- CAPTCHA container -->
        <cap-widget
                id="cap"
                data-cap-api-endpoint="https://captcha.app47.net/"
                data-cap-hidden-field-name="captcha-token">
        </cap-widget>
        <!-- Hidden input to carry proof -->
        <input type="hidden" id="captcha-token" name="captchaToken">
```

If you do want to change the name of the field in the form to store the token, then be sure to change it in the cap-widget as well as the id of the hidden input.

An example of this setup can be found in [index.html](web/index.html).

### Optional debug statement

If you would like to see some debug output in the browser console, you can register an event listener when the challenges are solved.

Either as an embedded script, or in a javascript file, add the following script

```javascript
  const widget = document.querySelector("#cap");

  widget.addEventListener("solve", function (e) {
    const token = e.detail.token;
    console.log("Token: " + token);
  });
```

## Validation Endpoint Usage

The second area to setup is to configure the validation end point. This will happen wherever the end point of the form is submitted. 
While a working example can found in [submit.py](lambda/submit.py), the steps to write your own validation end point are listed below.

1. Receive the form input and extract the captcha-token field from the form submission.
2. Post the validation token in `application/json` to the end point `https://captcha.app47.net/validate`
3. If the post is valid, you will get a http response `200` with a JSON payload.
4. Verify the payload of `{'success': true}`
