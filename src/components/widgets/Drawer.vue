<template>
    <v-navigation-drawer v-model="drawer" absolute temporary>
        <v-list v-for="i in items" :key="i.name">
            <v-list-tile v-ripple @click="emit(i.value)">
                <v-list-tile-content><v-list-tile-title>{{ i.name }}</v-list-tile-title></v-list-tile-content>
            </v-list-tile>
        </v-list>
    </v-navigation-drawer>
</template>
<script>
export default {
    name: 'Drawer',
    data() {
        return {
            drawer: false,
            items: [
                {
                    name: 'Home',
                    value: 'showList'
                },
                {
                    name: 'Help',
                    value: 'showHelp'
                },
                {
                    name: 'About',
                    value: 'showAbout'
                }
            ]
        }
    },
    methods: {
        setVisible(visible) {
            this.drawer = visible;
        },
        emit(value) {
            this.$emit(value);
            this.drawer = false;
        }
    }
};
</script>
