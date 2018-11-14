# -*- coding: utf-8 -*-

import pygame
from pygame.locals import*
import sys

SCREEN_SIZE = (640, 480)

pygame.init()
screen = pygame.display.set_mode(SCREEN_SIZE)
pygame.display.set_caption("pygameでゲーム!")

img = pygame.image.load("python.png").convert_alpha()
img_rect = img.get_rect()

hit_sound = pygame.mixer.Sound("hit.wav")

vx = vy = 300
clock = pygame.time.Clock()

pygame.mixer.music.load("tam-n11.mp3")
pygame.mixer.music.play(-1)


while True:
    time_passed = clock.tick(60)
    time_passed_seconds = time_passed / 1000.0
    img_rect.x += vx * time_passed_seconds
    img_rect.y += vy * time_passed_seconds

    if img_rect.left < 0 or img_rect.right > 640:
        hit_sound.play()
        vx = -vx
    if img_rect.top < 0 or img_rect.bottom > 480:
        hit_sound.play()
        vy = -vy

    
    screen.fill((0,0,255))
    screen.blit(img, img_rect)
    pygame.display.update()

    for event in pygame.event.get():
        if event.type == QUIT: sys.exit()
        if event.type == KEYDOWN:  # キーを押したとき
            # ESCキーならスクリプトを終了
            if event.key == K_ESCAPE:
                sys.exit()
