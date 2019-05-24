# Redfox2

This application is a Progressive Web App designed to be a simple & easy way to handle online PDFs.
This application was built in VueJS 2, however the core non-ui code is written in ES6 Javascript and can be re-used in whatever JS framework you desire.

### Further development

Redfox2 is not 100% finished and will require some additional tweaks in order to smoothly integrate into your environment.
To continue where we left off, you can look at the [issues](https://github.com/djcass44/redfox2/issues) section.
The issues detail the problems we have been having, what we have completed, as well as where we planned on going if we had more time.

The most important tweaks are:
* Changing the download URLs in [List.vue](src/components/List.vue)::created
* Making the app check the hash (e-tag) of the PDF before downloading (this stop it from re-downloading the PDF if nothing has changed).

## Gotcha's

There are a few things which need to be considered when using this project in production.

1. PWA Checklist

    PWAs have a number of specific requirements in order for the browser to detect it as a valid PWA.
    Google was kind enough to make a [checklist](https://developers.google.com/web/progressive-web-apps/checklist).
    The most important one is that the entire app **MUST BE HTTPS**.
    
2. CORS
    
    The application attempts to download PDFs from URLs which you define.
    These URLs must either be on the same URL which the app is hosted, or you must set the appropriate headers.
    
    *(our intention was to host PDFs in S3 and set CORS headers to allow app.tld to access the files)*

## Usage

There are two main methods of hosting this application.

1. Using docker (recommended)

```
# build the image
docker build -t redfox2 .
# run the image
docker run -p 80:80 redfox2
```
The application will now be available at http://localhost:80

2. Using a 'standard' webserver
```
# build the project
npm run build
# move the dist folder to your webserver
cp dist /path/to/your/webdir
```

## Development

1. Install the dependencies
    ```
    npm install
    ```
2. Run the development server
    ```
    # this will start the development server on 8080
    npm run serve
    ```

### Additional references

* [VueJS 2](https://vuejs.org/v2/guide/)
* [Progressive Web Apps](https://developers.google.com/web/progressive-web-apps/)
* [PWA Checklist](https://developers.google.com/web/progressive-web-apps/checklist)