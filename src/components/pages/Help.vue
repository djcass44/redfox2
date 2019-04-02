<template>
    <v-layout>
        <v-flex xs12 sm6 offset-sm3>
            <p class="subheading ml-3"><v-btn flat icon color="grey darken-1" @click="showList"><v-icon>arrow_back</v-icon></v-btn>Back to home</p>
            <h2 class="display-3 my-4 text-xs-center font-weight-light">Help</h2>
            <v-subheader inset>General</v-subheader>
            <v-card>
                <v-card-title primary-title>
                    <div>
                        <h3 class="headline mb-0">Title</h3>
                        <div>Content</div>
                    </div>
                </v-card-title>
            </v-card>
        </v-flex>
    </v-layout>
</template>
<script>
export default {
    name: 'Help',
    methods: {
        showList() {
            // Tell App.vue to switch the List.vue component into view
            this.$emit('showList');
        }
    }
};
</script>
