use bevy::prelude::*;


fn main() {
    App::new()
        .add_plugins(DefaultPlugins)
        .add_systems(Update, hello_world)
        .run();
}

fn hello_world() {
    println!("hello world");
}




// https://github.com/UnravelSports/rs-football-3d/blob/master/src/main.rs
