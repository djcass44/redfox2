<template>
	<v-layout>
		<v-flex xs12 sm6 offset-sm3>
			<p class="subheading ml-3"><v-btn flat icon color="grey darken-1" @click="showList"><v-icon>arrow_back</v-icon></v-btn>Back to home</p>
			<h2 class="display-3 my-4 text-xs-center font-weight-light">About</h2>
			<v-subheader inset>General</v-subheader>
			<v-card>
				<v-card-title primary-title>
					<div class="ma-2">
						<h3 class="headline">REDFOX2</h3>
						<span class="body-1">{{ content }}</span>
					</div>
					<div class="ma-2">
						<h3 class="headline">The team</h3>
						<span class="body-1">{{ team }}</span>
					</div>
				</v-card-title>
			</v-card>
		</v-flex>
	</v-layout>
</template>
<script>
    export default {
        name: 'About',
		data() {
			return {
				content: 'This application is a Progressive Web App designed to be a simple & easy way to handle online PDFs.',
				team: 'REDFOX2 was built by Django Cass, Heath  Craig, Harry Lucey & Sean McManus'
			}
		},
        methods: {
            showList() {
                // Tell App.vue to switch the List.vue component into view
                this.$emit('showList');
            }
        }
    };
</script>
