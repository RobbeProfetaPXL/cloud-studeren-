import { Component, OnInit, OnDestroy } from '@angular/core';
import { Subject } from 'rxjs';
import { takeUntil } from 'rxjs/operators';
import { CarrouselItem } from 'src/app/CarrouselItem.model';
import { TodoService } from 'src/app/services/todo.service';

@Component({
  selector: 'app-carrousel',
  templateUrl: './carrousel.component.html',
  styleUrls: ['./carrousel.component.css']
})
export class CarrouselComponent implements OnInit, OnDestroy {
  images!: CarrouselItem[];
  activeItem = 0;
  counter!: ReturnType<typeof setInterval>;
  private destroy$ = new Subject<void>();

  constructor(private todoService: TodoService) {}

  ngOnInit(): void {
    this.todoService.getCarrouselItems()
      .pipe(takeUntil(this.destroy$))
      .subscribe((data: CarrouselItem[]) => {
        this.images = data;
      });

    this.counter = setInterval(() => {
      if (this.images?.length) {
        this.activeItem = (this.activeItem >= this.images.length - 1) ? 0 : this.activeItem + 1;
      }
    }, 5000);
  }

  ngOnDestroy(): void {
    clearInterval(this.counter);
    this.destroy$.next();
    this.destroy$.complete();
  }

  checkIfActive(index: number) {
    return this.activeItem === index;
  }
}
