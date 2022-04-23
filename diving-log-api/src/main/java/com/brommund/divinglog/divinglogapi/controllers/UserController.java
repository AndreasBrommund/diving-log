package com.brommund.divinglog.divinglogapi.controllers;

import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

@RestController
public class UserController {
    final Flux<String> users = Flux.just("1","2","3");
    
    @RequestMapping(value = "/user/{id}", method = RequestMethod.GET)
    public Mono<String> user(@PathVariable("id") final String id) {
        return users.filter(u -> u.equals(id)).next();
    }
    
    @RequestMapping(value = "/users", method = RequestMethod.GET)
    public Flux<String> users() {
        return users;
    }
}
