package com.brommund.divinglog.divinglogapi.controllers;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;


@RestController
public class HomeController {
    @RequestMapping(value = "/", method = RequestMethod.GET)
    public Mono<String> user() {
        return Mono.just("Diving log");
    }
}

