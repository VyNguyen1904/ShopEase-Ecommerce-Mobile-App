package com.shopease.cart.config;

import com.shopease.cart.model.CartItem;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.JdkSerializationRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

@Configuration
public class CartRedisConfig {
    @Bean
    RedisTemplate<String, CartItem> cartRedisTemplate(RedisConnectionFactory connectionFactory) {
        RedisTemplate<String, CartItem> template = new RedisTemplate<>();
        template.setConnectionFactory(connectionFactory);
        template.setKeySerializer(new StringRedisSerializer());
        template.setHashKeySerializer(new JdkSerializationRedisSerializer());
        template.setHashValueSerializer(new JdkSerializationRedisSerializer());
        template.afterPropertiesSet();
        return template;
    }

    @Bean
    HashOperations<String, Long, CartItem> cartHashOperations(RedisTemplate<String, CartItem> cartRedisTemplate) {
        return cartRedisTemplate.opsForHash();
    }
}
