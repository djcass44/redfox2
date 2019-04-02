<template>
    <v-toolbar>
        <v-toolbar-side-icon v-ripple @click="open"></v-toolbar-side-icon>
            <v-toolbar-title>RF2</v-toolbar-title>
            <v-spacer></v-spacer>
            <v-toolbar-items class="hidden-xs-and-down">
            <v-btn icon flat @click="showHelp"><v-icon>help</v-icon></v-btn>
        </v-toolbar-items>
    </v-toolbar>
</template>
<script>
export default {
    name: 'Toolbar',
    methods: {
        open() {
            this.$emit('drawer', true);
        },
        showHelp() {
            this.$emit('showHelp');
        }
    }
};
</script>
