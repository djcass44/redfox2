<template>
	<v-layout>
		<v-flex xs12 sm6 offset-sm3>
			<div v-if="loading > 0" class="text-xs-center pa-4">
				<v-progress-circular :size="50" color="accent" indeterminate></v-progress-circular>
				<p class="pa-2">Loading data...</p>
			</div>
			<v-alert :value="online === false" type="warning" outline>
				<p class="headline px-3">You are offline.</p>
				<p class="px-3">Everything is still available, however in order to get updates &amp; new documents you will need to connect to the internet.</p>
			</v-alert>
			<v-alert :value="updated === true && loading === 0" color="info" icon="info" outline>
				<v-layout fill-height>
					<v-flex xs10 class="text-xs-left pa-3 subheading">New content is available</v-flex>
					<v-flex xs2 class="text-xs-right"><v-btn @click="loadOnceDone">Update</v-btn></v-flex>
				</v-layout>
			</v-alert>
			<v-subheader inset v-if="loading === 0"><div>Available</div></v-subheader>
			<v-card v-if="items.length > 0" class="m2-card">
				<v-list two-line subheader>
					<v-slide-y-transition class="py-0" group>
						<v-list-tile v-for="item in items" :key="item.name" avatar @click="" :color="getCardColour(item)">
							<!-- <v-list-tile-avatar color="primary" v-if="item.loaded === true"><v-icon dark>book</v-icon></v-list-tile-avatar>
							<v-list-tile-avatar color="accent" v-if="item.loaded !== true"><v-icon dark>error</v-icon></v-list-tile-avatar> -->
							<v-list-tile-content>
								<v-list-tile-title>{{ item.name }}</v-list-tile-title>
								<v-list-tile-sub-title>{{ item.date }}</v-list-tile-sub-title>
							</v-list-tile-content>
							<v-list-tile-action>
								<v-btn icon ripple @click="openAsContent2(item)" v-if="item.loaded === true"><v-icon color="primary darken-2">visibility</v-icon></v-btn>
								<v-btn icon ripple @click="showHelp" v-else><v-icon color="accent darken-2">info</v-icon></v-btn>
							</v-list-tile-action>
						</v-list-tile>
					</v-slide-y-transition>
				</v-list>
			</v-card>
			<p v-if="items.length === 0" class="text-xs-center ma-4 subheading">No documents available.</p>
			<v-subheader inset v-if="badItems.length > 0 && loading === 0"><div>Unavailable</div></v-subheader>
			<!-- This should exactly match the above block -->
			<!-- TODO move this into a subcomponent -->
			<v-card v-if="badItems.length > 0" class="m2-card">
				<v-list two-line subheader>
					<v-slide-y-transition class="py-0" group>
						<v-list-tile v-for="item in badItems" :key="item.name" avatar @click="" :color="getCardColour(item)">
							<!-- <v-list-tile-avatar color="primary" v-if="item.loaded === true"><v-icon dark>book</v-icon></v-list-tile-avatar>
							<v-list-tile-avatar color="accent" v-if="item.loaded !== true"><v-icon dark>error</v-icon></v-list-tile-avatar> -->
							<v-list-tile-content>
								<v-list-tile-title>{{ item.name }}</v-list-tile-title>
								<v-list-tile-sub-title>{{ item.date }}</v-list-tile-sub-title>
							</v-list-tile-content>
							<v-list-tile-action>
								<v-btn icon ripple @click="showHelp"><v-icon color="accent darken-2">info</v-icon></v-btn>
							</v-list-tile-action>
						</v-list-tile>
					</v-slide-y-transition>
				</v-list>
			</v-card>
			<Network @setNetwork="setNetwork"></Network>
			<div class="text-xs-center" v-if="dev">
				<v-btn icon ripple @click="dev2 = !dev2"><v-icon>adb</v-icon></v-btn>
			</div>
			<Dev v-if="dev2 === true"></Dev>
		</v-flex>
	</v-layout>
</template>
<script>
    import Network from "./Network.vue";
    import Dev from "./Dev.vue";

    import axios from "axios";
    import moment from "moment-timezone";

    import {VALUE_NO_CONTENT} from "../var.js";

    export default {
        name: 'List',
        components: {
            Network,
            Dev
        },
        data() {
            return {
                dev2: false,
                loading: 0,
                online: true,
                items: [],
                badItems: [],
                updated: true
            }
        },
        computed: {
            dev: function() {
                return process.env.NODE_ENV === "development"
            }
        },
        methods: {
            showHelp() {
                this.$emit('showHelp');
            },
            getCardColour(item) {
                if(item.loaded === true) return "black";
                else return "accent darken-2";
            },
            setNetwork(online) {
                this.online = online;
                this.loadOfflineResources(); // Load items when network connectivity is known
            },
			/**
	         * Attempt to download a number of resources
			 * Provide an array of urls
	         */
            downloadResource(items) {
                let that = this;
                for(let i = 0; i < items.length; i++) {
                    this.loading ++;
                    let uri = items[i];
                    console.log(`Downloading resources from ${uri}, [${i}/${items.length}]`);
                    let name = uri.split("/").pop(); // Get the filename
                    that.$getItem(name).then((val) => {
                        let content = null;
                        if(val != null && val.data != null) content = val.data;
                        // let timestamp = val.timestamp;
                        if(typeof content === "string" && content.includes("application/pdf")) {
                            console.log(`Found existing item: ${name}`);
                            that.loading --;
                            return;
                        }
                        axios({
                            url: uri,
                            method: 'GET',
                            responseType: 'blob',
                            headers: {
                                'Content-Type': 'application/pdf'
                            }
                        }).then(r => {
                            let reader = new FileReader();
                            reader.onloadend = () => {
                                let data = reader.result;
                                that.$setItem(name, {
                                    data: data.toString(),
									timestamp: new Date().getTime()
                                });
                            };
                            reader.readAsDataURL(r.data);
                            console.log(`Downloaded resource: ${name}`);
                            that.loading--;
                            that.updated = true;
                        }).catch(err => {
                            // 'no-content' is arbitrary, but no proper PDF will only contain it
							// TODO check the age of the timestamp for a newer version?
                            if(that.$getItem(name) !== null && that.$getItem(name).data !== VALUE_NO_CONTENT)
                                that.$setItem(name, {
                                    data: VALUE_NO_CONTENT,
									timestamp: 0
                                });
                            console.log(`Failed to load: ${name}, will set as VALUE_NO_CONTENT`);
                            console.log(err);
                            that.loading --;
                            that.updated = true;
                        });
                    });
                }
            },
            /* This is the important part and also the most broken
			https://stackoverflow.com/questions/24485077/how-to-open-blob-url-on-chrome-ios
			*/
			openAsContent2(item) {
                if(item.loaded === false) {
                    console.log("Trying to open invalid item, returning");
                    return;
                }
                console.log(`Opening item: ${item.name}, ${item.data}`);
                let blob = new Blob([item.data], {type: "application/pdf"});
                let userAgent = navigator.userAgent;
                if (window.navigator.msSaveOrOpenBlob) { //IE 11+
                    console.log("Assuming IE 11+");
                    window.navigator.msSaveOrOpenBlob(blob, item.name);
                }
                else if (userAgent.match('FxiOS')) { //FF iOS
                    alert("Cannot display on FF iOS");
                }
				else if (userAgent.match('CriOS')) { //Chrome iOS
                    console.log("Assuming Chrome iOS");
                    let reader = new FileReader();
                    reader.onloadend = function () { $window.open(reader.result);};
					reader.readAsDataURL(blob);
				}
				else if (userAgent.match(/iPad/i) || userAgent.match(/iPhone/i)) { //Safari & Opera iOS
					console.log("Assuming Safari or Opera iOS");
                    window.location.href = $window.URL.createObjectURL(blob);
				}
				else {
					console.log("Opening using v1");
                    let reader = new FileReader();
                    reader.onloadend = () => {
                        window.open(reader.result);
                    };
                    reader.readAsDataURL(blob);
                }
			},
            /**
             * Try to load resources after we have finished any loading
             */
            loadOnceDone() {
                if(this.loading === 0) {
                    this.loadOfflineResources();
                    return;
                }
                let that = this;
                setTimeout(() => {
                    that.loadOnceDone();
                }, 100);
            },
            /**
             * Load data from LocalStorage
             * https://developer.mozilla.org/en-US/docs/Web/API/Window/localStorage
             */
            loadOfflineResources() {
                let that = this;
                // Make sure we're not loading anything before trying to reload data
				// This is somewhat redundant if we are using loadOnceDone properly
                if(this.loading > 0) {
                    setTimeout(() => {
                        that.loadOfflineResources();
                    }, 100);
                    return;
                }
                this.loading ++;
                this.items = [];
                // TODO make sure that TZ is local, it would always default to UTC for me - django
                let tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
                this.$iterateStorage(function (value, key) {
                    let valid = true;
                    let content = value.data;
                    let timestamp = value.timestamp;
                    let date = 'Never downloaded';
                    if(timestamp > 0) date = `Last updated: ${moment(timestamp).tz(tz).format('MMM Do YY, h:mm')}`;
                    if(content === VALUE_NO_CONTENT) valid = false;
                    let blob = that.dataURItoBlob(content);
                    let item = {
                        name: key,
                        data: blob,
                        loaded: valid,
                        date: date
                    };
                    // Separate items into groups (loaded vs failed to load)
                    if(valid === true) {
                        that.items.push(item);
                    }
                    else {
                        that.badItems.push(item);
                    }
                }, err => {
                    if(!err) {
                        console.log("Iteration has completed!");
                    }
                });
                this.updated = false;
                this.loading --;
            },
            dataURItoBlob: function(dataURI) {
                if(dataURI === VALUE_NO_CONTENT) return dataURI;
                // convert base64 to raw binary data held in a string
                // doesn't handle URLEncoded DataURIs - see SO answer #6850276 for code that does this
                let byteString = atob(dataURI.split(',')[1]);

                // separate out the mime component
                // let mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];

                // write the bytes of the string to an ArrayBuffer
                let ab = new ArrayBuffer(byteString.length);
                let ia = new Uint8Array(ab);
                for (let i = 0; i < byteString.length; i++) {
                    ia[i] = byteString.charCodeAt(i);
                }

                // write the ArrayBuffer to a blob, and you're done
                return new Blob([ab]);
            }
        },
        created() {
            this.online = navigator.onLine;
            // TODO check S3 for files to download
            this.downloadResource([
                "https://s2.q4cdn.com/235752014/files/doc_downloads/test.pdf",
                "https://www.act.org/content/dam/act/unsecured/documents/Preparing-for-the-ACT.pdf",
                "https://upload.wikimedia.org/wikipedia/commons/d/d3/Test.pdf"
            ]);
        }
    };
</script>
