<template>
    <v-layout>
        <v-flex xs12 sm6 offset-sm3>
            <div v-if="loading > 0" class="text-xs-center pa-4">
                <v-progress-circular :size="50" color="accent" indeterminate></v-progress-circular>
                <p class="pa-2">Loading data...</p>
            </div>
            <v-alert :value="online === false" color="warning" icon="warning" outline>
                <p class="headline px-3">You are offline.</p>
                <p class="px-3">Everything is still available, however in order to get updates &amp; new documents you will need to connect to the internet.</p>
            </v-alert>
            <v-alert :value="updated === true && loading === 0" color="info" icon="info" outline>
                <v-layout fill-height>
                    <v-flex xs10 class="text-xs-left pa-3 subheading">New content is available</v-flex>
                    <v-flex xs2 class="text-xs-right"><v-btn @click="loadOnceDone">Update</v-btn></v-flex>
                </v-layout>
            </v-alert>
            <v-subheader inset>
                <div v-if="filter !== ''">Documents ({{ filtered.length }} results)</div>
                <div v-if="filter === ''">Documents</div>
            </v-subheader>
            <v-card v-if="filtered.length > 0" class="m2-card">
                <v-list two-line subheader>
                    <v-slide-y-transition class="py-0" group>
                        <v-list-tile v-for="item in filtered" :key="item.name" avatar @click="">
                            <v-list-tile-avatar color="primary darken-2" v-if="item.loaded === true"><v-icon dark>book</v-icon></v-list-tile-avatar>
                            <v-list-tile-avatar color="accent darken-2" v-if="item.loaded !== true"><v-icon dark>cloud_off</v-icon></v-list-tile-avatar>
                            <v-list-tile-content>
                                <v-list-tile-title>{{ item.name }}</v-list-tile-title>
                                <v-list-tile-sub-title>Last updated {{ item.date }}</v-list-tile-sub-title>
                            </v-list-tile-content>
                            <v-list-tile-action v-if="item.loaded === true">
                                <v-btn icon ripple @click="openAsContent(item)"><v-icon>cloud_download</v-icon></v-btn>
                            </v-list-tile-action>
                        </v-list-tile>
                    </v-slide-y-transition>
                </v-list>
            </v-card>
            <Network @setNetwork="setNetwork"></Network>
            <Dev></Dev>
        </v-flex>
    </v-layout>
</template>
<script>
import Network from "./Network.vue";
import Dev from "./Dev.vue";

import axios from "axios";
import moment from "moment-timezone";

export default {
    name: 'List',
    components: {
        Network,
        Dev
    },
    data() {
        return {
            loading: 0,
            online: true,
            items: [],
            filtered: [],
            filter: '',
            updated: true
        }
    },
    methods: {
        setNetwork(online) {
            this.online = online;
            this.loadOfflineResources(); // Load items when network connectivity is known
        },
        filterItems() {
            // TODO do actual search stuff
            this.filtered = this.items;
        },
        downloadResource(items) {
            let that = this;
            for(let i = 0; i < items.length; i++) {
                this.loading ++;
                let uri = items[i];
                console.log(`Downloading resources from ${uri}, [${i}/${items.length}]`);
                let name = uri.split("/").pop(); // Get the filename
                axios({
                    url: uri,
                    method: 'GET',
                    responseType: 'blob',
                    headers: {
                        'Content-Type': 'application/pdf'
                    }
                }).then(r => {
                    that.$setItem(name, r.data);
                    console.log(`Downloaded resource: ${name}`);
                    that.loading--;
                    that.updated = true;
                }).catch(err => {
                    // 'no-content' is arbitrary, but no proper PDF will only contain it
                    if(that.$getItem(name) !== null && that.$getItem(name) !== 'no-content')
                        that.$setItem(name, 'no-content');
                    console.log(`Failed to load: ${name}, will set as 'no-content'`);
                    console.log(err);
                    that.loading --;
                    that.updated = true;
                });
            }
        },
        openAsContent(item) {
            if(item.loaded === false) {
                console.log("Trying to open invalid item, returning");
                return;
            }
            console.log(`Opening item: ${item.name}, ${item.data}`);
            let b = new Blob([item.data], {type: "application/pdf"});
            const data = window.URL.createObjectURL(b);
            let link = document.createElement('a');
            link.href = data;
            // TODO open in new window instead of downloading
            link.download = item.name;
            link.click();
            setTimeout(function() {
                window.URL.revokeObjectURL(data);
            }, 100); // Required by Firefox
        },
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
        loadOfflineResources() {
            let that = this;
            // Make sure we're not loading anything before trying to reload data
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
            this.$iterateStorage(function (value, key, i) {
                console.log([key, value]);
                let valid = true;
                if(value === 'no-content') valid = false;
                that.items.push({
                    name: key,
                    data: value,
                    loaded: valid,
                    date: moment().tz(tz).format('MMM Do YY, h:mm') // Use the current time
                });
            }, err => {
                if(!err) {
                    console.log("Iteration has completed!");
                }
            });
            this.updated = false;
            this.filterItems();
            this.loading --;
        }
    },
    created() {
        this.filterItems();

        this.online = navigator.onLine;

        // this.$setStorageDriver(localforage.INDEXEDDB);
        this.downloadResource(["http://s2.q4cdn.com/235752014/files/doc_downloads/test.pdf", "https://www.act.org/content/dam/act/unsecured/documents/Preparing-for-the-ACT.pdf"]);
    }
};
</script>
