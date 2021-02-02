# Projects for the STM32 Nucleo F446RE

Note that the F446RE is not directly supported by the Ada Drivers Library (ADL), however we can use the Nucleo F446ZE runtime
(basically the same microcontroller). 

Please note, that the NUCLEO F446ZE board is a little bit different from the Nucleo F446RE board:

- the F446RE has only one user LED, which is connected to PA5


## Flashing 

I use pyocd for flashing instead of using st-link (which is used by the ADL). Support for the F446RE is not built-in for pyocd. 
But you can install the pack with 
     
     pyocd pack --install STM32F446

If you are developing with linux, then also check the udev rules. 
The following page has a useful tutorial for doing this: [Rust Discovery](https://docs.rust-embedded.org/discovery/03-setup/linux.html) 




