package com.shopease.product.model;

import jakarta.persistence.*;
import lombok.Getter;

@Getter
@Entity
@Table(name = "categories")
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String slug;

    @Column(length = 1000)
    private String description;

    private String iconUrl;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private Category parent;

    @Column(nullable = false)
    private int displayOrder;

    @Column(nullable = false)
    private boolean active;

    protected Category() {
    }

    public Category(String name, String slug, String description, String iconUrl, Category parent, int displayOrder, boolean active) {
        this.name = name;
        this.slug = slug;
        this.description = description;
        this.iconUrl = iconUrl;
        this.parent = parent;
        this.displayOrder = displayOrder;
        this.active = active;
    }

    public void update(String name, String slug, String description, String iconUrl, Category parent, int displayOrder, boolean active) {
        this.name = name;
        this.slug = slug;
        this.description = description;
        this.iconUrl = iconUrl;
        this.parent = parent;
        this.displayOrder = displayOrder;
        this.active = active;
    }
}
